From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Tue, 9 Nov 2004 22:13:04 -0800
Message-ID: <20041109221304.7f9c17af.davem@davemloft.net>
References: <418B4C7C.8000402@crocom.com.pl>
	<418EA032.7050507@trash.net>
	<418ECE85.9090203@trash.net>
	<20041108135431.GE31969@postel.suug.ch>
	<418F9AD0.1040701@trash.net>
	<20041108183300.GF31969@postel.suug.ch>
	<418FCD0A.4040202@trash.net>
	<20041109161816.425ad7d6.davem@davemloft.net>
	<41916369.7020901@trash.net>
	<41916709.8020402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, spam@crocom.com.pl, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41916709.8020402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Nov 2004 01:55:37 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This is the final patch:
 ...
> #   [PKT_SCHED]: Unlink inner qdiscs immediately in qdisc_destroy

I understand how this work now.  Thanks for the
explanation and updated patch.

Applied.
