From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Intel and TOE in the news
Date: Tue, 22 Feb 2005 13:42:25 -0800
Message-ID: <421BA741.4050201@hp.com>
References: <200502222131.j1MLVHDD029755@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <200502222131.j1MLVHDD029755@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
> No wait, "paste in" only packets that are already received when a traffic
> interrupt comes...

Ah, so it is ass-u-me-ing that there is little or no packet loss?

How about when the driver is polling instead of taking interrupts?  Will the 
driver "see" the RSO segment-in-progress or will it be hidden?

rick jones
