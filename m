From: "David S. Miller" <davem@redhat.com>
Subject: Re: Getting details about an 802.1q VLAN interface from userspace
Date: Tue, 18 Feb 2003 19:13:39 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218.191339.23709806.davem@redhat.com>
References: <20030213143921.A21977@cisco.com>
	<20030217.182915.41644338.davem@redhat.com>
	<20030218214714.J25195@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wjhun@cisco.com, greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <20030218214714.J25195@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Tue, 18 Feb 2003 21:48:34 -0500 (EST)
   
   I think these should be new attributes to RTM_*LINK.
   No need to define a new message.

I had overlooked this, you're certainly right.
