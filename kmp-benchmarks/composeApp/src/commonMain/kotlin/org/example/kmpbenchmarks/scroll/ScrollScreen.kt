import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
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
import kotlinx.coroutines.launch
import org.example.kmpbenchmarks.scroll.ScrollController
import org.jetbrains.compose.resources.painterResource
import kmp_benchmarks.composeapp.generated.resources.Res
import kmp_benchmarks.composeapp.generated.resources.img1mb

@Composable
fun ScrollScreen(onDone: () -> Unit) {
    val listState = rememberLazyListState()
    val isScrolling by ScrollController.isScrolling.collectAsState()
    val scope = rememberCoroutineScope()

    var scrollJob by remember { mutableStateOf<Job?>(null) }

    // Start scrolling when triggered
    LaunchedEffect(isScrolling) {
        if (isScrolling) {
            scrollJob = scope.launch {
                var index = 0
                while (ScrollController.isScrolling.value) {
                    listState.animateScrollToItem(index)
                    index++
                    if (index >= 100) index = 0
                }
                onDone()
            }
        } else {
            scrollJob?.cancel()
            scrollJob = null
            onDone()
        }
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = listState,
        horizontalAlignment = Alignment.CenterHorizontally // Center image + text
    ) {
        items(100) { index ->
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(vertical = 16.dp)
            ) {
                Image(
                    painter = painterResource(Res.drawable.img1mb),
                    contentDescription = "Item image",
                    modifier = Modifier
                        .size(width = 600.dp, height = 400.dp),
                    contentScale = ContentScale.Fit
                )
                Text(
                    text = "Item $index",
                    modifier = Modifier.padding(top = 16.dp, bottom = 24.dp)
                )
            }
        }
    }
}
