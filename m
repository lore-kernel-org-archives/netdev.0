From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Mon, 15 Dec 2003 23:46:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215234624.7ce46dc5.davem@redhat.com>
References: <Pine.LNX.4.44.0312151304350.8670-200000@sorbus2.navaho>
	<20031215171732.4877acd1.davem@redhat.com>
	<200312160843.58992.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steve@navaho.co.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312160843.58992.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Dec 2003 08:43:58 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> You are truly amazing.

Don't make me blush in public :)

> Dave, I'll cook up a slightly different patch for you later, I think
> nf_bridge->hh is now a bad name, I'll change it into nf_bridge->data.

Great, I hope we've got this one nailed.
