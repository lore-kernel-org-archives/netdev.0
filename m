From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 25 Apr 2005 07:25:55 -0400
Message-ID: <1114428355.7669.157.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <1114173195.7679.30.camel@localhost.localdomain>
	 <20050422172108.GA10598@muc.de>
	 <1114193902.7978.39.camel@localhost.localdomain>
	 <20050422183004.GC10598@muc.de>
	 <Pine.LNX.4.61.0504221131350.15052@linux.site>
	 <20050422115230.6037a362.davem@davemloft.net>
	 <Pine.LNX.4.61.0504241845070.2934@linux.site>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, ak@muc.de, gnb@sgi.com,
        jesse.brandeburg@intel.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504241845070.2934@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Dang, I just noticed you used TCP. Could you use UDP please?

While the suspect may be PIO/s - lets be scientific and prove it.
So please collect all the data i requested with UDP and if you can 
please also retry with e1000 and latest driver they have (this should
help rule out - hopefully - any tg3 driver related issues).

cheers,
jamal
