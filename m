From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Sat, 07 Jun 2003 02:05:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607.020528.68152135.davem@redhat.com>
References: <20030606145835.3a263df8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com,
   viro@parcelfarce.linux.theplanet.co.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030606145835.3a263df8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Fri, 6 Jun 2003 14:58:35 -0700
   
   Phase I:  introduces release_netdev which is the hook to allow later
      changes to hold onto the net device after the device has potentially
      unloaded.  Includes patch for the easy to fix devices. 

Besides naming (thought this was going to be named netdev_drop)
I have no problems.

Al?
