From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Fri, 7 Jun 2013 20:46:22 +0200
Message-ID: <20130607184622.GA24906@uio.no>
References: <20130607030648.GA28618@home.goodmis.org>
 <20130607085421.GF15083@uio.no>
 <1370612441.24311.411.camel@edumazet-glaptop>
 <1370618100.9844.73.camel@gandalf.local.home>
 <20130607154634.GA7529@uio.no>
 <1370621543.9844.78.camel@gandalf.local.home>
 <20130607175233.GA20230@uio.no>
 <1370629568.9844.87.camel@gandalf.local.home>
 <20130607183438.GA23064@uio.no>
 <1370630659.9844.89.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370630659.9844.89.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 02:44:19PM -0400, Steven Rostedt wrote:
> Do know if you have CONFIG_NET_NS set in your .config?

Sorry, I forgot to answer this: No, it is not set.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
