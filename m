From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] bridge: fdb add and delete
	tracepoints
Date: Tue, 29 Aug 2017 23:35:24 +0300
Message-ID: <0c886358-0771-ed3c-c97f-f8366194eca2@cumulusnetworks.com>
References: <1504037817-38107-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	bridge@lists.linux-foundation.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1504037817-38107-1-git-send-email-roopa@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 29/08/17 23:16, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> A few useful tracepoints to trace bridge forwarding
> database updates.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v2: address comments from florian
> v3: remove stray character '=' in print (pointed out by florian)
> 
>  include/trace/events/bridge.h |   98 +++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_fdb.c           |    7 +++
>  net/core/net-traces.c         |    6 +++
>  3 files changed, 111 insertions(+)
>  create mode 100644 include/trace/events/bridge.h
> 

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
