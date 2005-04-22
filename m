From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 11:52:30 -0700
Message-ID: <20050422115230.6037a362.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422183004.GC10598@muc.de>
	<Pine.LNX.4.61.0504221131350.15052@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, hadi@cyberus.ca, gnb@sgi.com, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504221131350.15052@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 11:37:17 -0700 (PDT)
Arthur Kepner <akepner@sgi.com> wrote:

> I'm going to try to get some new (2.6.12-rc2) data this weekend.

That sounds great.  See the other email I posted (you were CC:'d)
where I show a patch to tg3 to minimally enable some hw interrupt
coalescing which might help.  It would be great to see what that
kind of change does for your tests.

Thanks.
