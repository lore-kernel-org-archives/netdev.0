From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net] ip6tnl: fix use after free of fb_tnl_dev
Date: Thu, 14 Nov 2013 17:18:21 -0500
Message-ID: <20131114171821.6500541d@gandalf.local.home>
References: <20131113211430.1ad3bb7d@gandalf.local.home>
	<1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
	<20131114.170529.1627250972818871118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, gregkh@linuxfoundation.org,
	williams@redhat.com, linux-rt-users@vger.kernel.org,
	lclaudio@uudg.org, netdev@vger.kernel.org, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131114.170529.1627250972818871118.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Nov 2013 17:05:29 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

 
> Applied and queued up for -stable, thanks for being so proactive about this
> Nicolas.

I should also note that I added this back to 3.10.18 and the bug goes
away.

If it's not too late:

Tested-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve
