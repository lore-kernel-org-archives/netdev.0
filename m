From: Simon Roscic <simon.roscic@chello.at>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Wed, 12 Jan 2005 23:25:23 +0100
Message-ID: <200501122325.23284.simon.roscic@chello.at>
References: <200412240002.13206.simon.roscic@chello.at> <41E44476.20303@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41E44476.20303@tpack.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> netlink has messed up the send buffer accounting, when trimming a skb.
>
> Patch below should fix this for ethertap. Could you give it a try?
>
> -Tommy

Thanks a lot! Your patch fixed the bug.

bye,
 simon.
