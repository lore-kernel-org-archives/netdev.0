From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 31 Jan 2004 17:26:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075587994.1036.231.camel@jzny.localdomain>
References: <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <1075127396.1746.370.camel@jzny.localdomain>
	 <20040131185231.GA2608@usr.lcm.msu.ru>
	 <1075580812.1035.83.camel@jzny.localdomain>
	 <20040131205326.GA3089@usr.lcm.msu.ru>
	 <1075584318.1033.159.camel@jzny.localdomain>
	 <20040131213236.GA3451@usr.lcm.msu.ru>
	 <1075585764.1035.192.camel@jzny.localdomain>
	 <20040131215821.GA3615@usr.lcm.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040131215821.GA3615@usr.lcm.msu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-31 at 16:58, Vladimir B. Savkin wrote:

> Well, not, the primary reason being that there would be no single class
> with appropriate bandwith limit (ceil). There would be multiple classes,

Ok - i think you made your point. 
So i should add that a third condition is there are multiple devices
towards the clients.
You have convinced me there is value in such a scheme as IMQ provides
for such conditions. As it is right now though IMQ needs to have the
right abstraction (and not be dependent on netfilter).And may be we
could abuse it to do other things. 
Let me hear from Tomas and then we should take it from there.

cheers,
jamal
