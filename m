From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Still bug-hunting
Date: Sat, 5 Mar 2005 21:32:17 +0100
Message-ID: <20050305203216.GA25116@electric-eye.fr.zoreil.com>
References: <4229F2EC.8090103@rapidforum.com> <20050305102918.15fd422c.davem@davemloft.net> <4229FC15.3070408@rapidforum.com> <20050305104854.45106335.davem@davemloft.net> <422A0079.4080806@rapidforum.com> <20050305105706.2c8a6975.davem@davemloft.net> <422A0354.3080800@rapidforum.com> <20050305195712.GO31837@postel.suug.ch> <422A10BC.2060706@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <422A10BC.2060706@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid <webmaster@rapidforum.com> :
[...]
> I just asked for a way how to change the dynamic memory-allocation for 
> buffers to a static one. I dont think that this is much work and is a quite 
> direct task.

Simple answer: rewrite alloc_skb and friends.

--
Ueimor
