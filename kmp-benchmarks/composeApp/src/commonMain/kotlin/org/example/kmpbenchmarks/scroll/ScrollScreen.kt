import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.example.kmpbenchmarks.scroll.ScrollController

@Composable
fun ScrollingScreen(onDone: () -> Unit) {
    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()
    val scrolling = ScrollController.scrollingActive.collectAsState()

    LaunchedEffect(scrolling.value) {
        if (scrolling.value) {
            while (scrolling.value) {
                scope.launch {
                    listState.animateScrollToItem((listState.firstVisibleItemIndex + 1) % 1000)
                }
                delay(16L) // ~60 times/sec
            }
            onDone()
        }
    }

    LazyColumn(state = listState, modifier = Modifier.fillMaxSize()) {
        items(1000) {
            Text("Item $it")
        }
    }
}
