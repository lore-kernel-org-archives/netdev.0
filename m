From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] MAINTAINERS: Add tools/net to NETWORKING [GENERAL]
Date: Tue, 11 Mar 2014 16:52:57 +0100
Message-ID: <531F3159.6060607@redhat.com>
References: <1394535984-17924-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394535984-17924-1-git-send-email-tklauser@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2014 12:06 PM, Tobias Klauser wrote:
> Make sure patches for these tools go to the netdev list as well.
>
> References: https://marc.info/?l=linux-kernel&m=139450284501328&w=2
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>   MAINTAINERS |    1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ab32ad5..fa7b379 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6042,6 +6042,7 @@ F:	include/linux/netdevice.h
>   F:	include/uapi/linux/in.h
>   F:	include/uapi/linux/net.h
>   F:	include/uapi/linux/netdevice.h
> +F:	tools/net/

We should perhaps also add an entry for networking
selftests later on, that is:

   tools/testing/selftests/net/

>   NETWORKING [IPv4/IPv6]
>   M:	"David S. Miller" <davem@davemloft.net>
>
