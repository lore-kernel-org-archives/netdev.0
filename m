From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use setup_timer and mod_timer
Date: Fri, 27 Feb 2015 12:41:00 -0500 (EST)
Message-ID: <20150227.124100.2151634512824956135.davem@davemloft.net>
References: <20150227084812.GA15946@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227084812.GA15946@vaishali-Ideapad-Z570>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm not applying these patches.

Your Subject lines need adjusting.  You have to say what specific
thing you are touching in each change.

All of your changes say "net: " therefore someone scanning the
"git shortlog" can't tell what might be difference in one of
these changes vs. another.
