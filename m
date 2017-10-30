From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: bridge: add neigh_suppress to
	bridge port policies
Date: Mon, 30 Oct 2017 07:36:19 -0700
Message-ID: <CAJieiUg2uTXyHcREQRHz+cJdTNN0iZC4tnr9ym4rZhipLQdKpg@mail.gmail.com>
References: <1509360993-25227-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"davem@davemloft.net" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1509360993-25227-1-git-send-email-nikolay@cumulusnetworks.com>
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

On Mon, Oct 30, 2017 at 3:56 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> Add an entry for IFLA_BRPORT_NEIGH_SUPPRESS to bridge port policies.
>
> Fixes: 821f1b21cabb ("bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks Nikolay.
