From: "David S. Miller" <davem@redhat.com>
Subject: Re: VLAN patches
Date: Mon, 07 Oct 2002 00:06:27 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007.000627.50595749.davem@redhat.com>
References: <20021006.194654.35505461.davem@redhat.com>
	<3DA1010A.8020202@candelatech.com>
	<3DA13332.4080109@mrv.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, hadi@cyberus.ca, Bjorn.Andersson@ebc.ericsson.se,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: emann@mrv.com
In-Reply-To: <3DA13332.4080109@mrv.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Eran Mann <emann@mrv.com>
   Date: Mon, 07 Oct 2002 09:09:38 +0200
   
   Regarding the 0 VID it is indeed used for priority-only frames. 
   Shouldn't it be supported by alowing the user to configure a priority 
   map for the ethernet device (rather than creating another user-visible 
   device?

I don't have any opinion about this, besides the fact that if
the device based interface we have now can do whatever the user
wants we should not add a new configuration mechanism just to provide
some alias that effectively accomplishes the same task.
