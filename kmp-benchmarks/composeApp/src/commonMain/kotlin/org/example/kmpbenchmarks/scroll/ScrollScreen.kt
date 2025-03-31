import androidx.compose.foundation.Image
import androidx.compose.foundation.gestures.animateScrollBy
import androidx.compose.foundation.gestures.scrollBy
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.example.kmpbenchmarks.scroll.ScrollController
import org.jetbrains.compose.resources.painterResource
import kmp_benchmarks.composeapp.generated.resources.Res
import kmp_benchmarks.composeapp.generated.resources.example_img

@Composable
fun ScrollScreen(onDone: () -> Unit) {
    val listState = rememberLazyListState()
    val isScrolling by ScrollController.isScrolling.collectAsState()
    val scope = rememberCoroutineScope()

    var scrollJob by remember { mutableStateOf<Job?>(null) }

    // Simulate the scrolling behavior
    LaunchedEffect(isScrolling) {
        if (isScrolling) {
            scrollJob = scope.launch {
                while (ScrollController.isScrolling.value) {
                    listState.scrollBy(250f)
                    delay(10L)
                }
                onDone()
            }
        } else {
            onDone()
            scrollJob?.cancel()
            scrollJob = null
        }
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = listState,
    ) {
        items(1000) { index ->
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp)
            ) {
                Image(
                    painter = painterResource(Res.drawable.example_img),
                    contentDescription = "Item image",
                    modifier = Modifier
                        .size(64.dp)
                        .padding(end = 8.dp),
                    contentScale = ContentScale.Crop
                )
                Text("Item $index")
            }
        }
    }
}
