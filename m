From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] Update .gitignore
Date: Sat, 26 May 2012 22:19:51 +0200
Message-ID: <20120526201951.GA452@1984>
References: <20120526180654.GB31938@1984>
 <1338058955-5789-1-git-send-email-jengelh@inai.de>
 <1338058955-5789-3-git-send-email-jengelh@inai.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1338058955-5789-3-git-send-email-jengelh@inai.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied, thanks Jan.

On Sat, May 26, 2012 at 09:02:35PM +0200, Jan Engelhardt wrote:
> ---
>  .gitignore     |    1 +
>  src/.gitignore |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/.gitignore b/.gitignore
> index 928e44b..f7a5fc7 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -1,5 +1,6 @@
>  .deps/
>  .libs/
> +.dirstamp
>  Makefile
>  Makefile.in
>  *.o
> diff --git a/src/.gitignore b/src/.gitignore
> index 6e6763d..55a0d27 100644
> --- a/src/.gitignore
> +++ b/src/.gitignore
> @@ -1,5 +1,6 @@
>  /conntrack
>  /conntrackd
> +/nfct
>  
>  /read_config_lex.c
>  /read_config_yy.c
> -- 
> 1.7.7
> 
