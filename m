From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:55:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.155533.63022973.davem@redhat.com>
References: <OFC2446DB8.6D4DA3ED-ON85256D47.007C79EE@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stekloff@us.ibm.com, janiceg@us.ibm.com, jgarzik@pobox.com,
   kenistonj@us.ibm.com, lkessler@us.ibm.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: girouard@us.ibm.com
In-Reply-To: <OFC2446DB8.6D4DA3ED-ON85256D47.007C79EE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Janice Girouard <girouard@us.ibm.com>
   Date: Mon, 16 Jun 2003 17:50:08 -0500
   
   One possible suggestion would be to submit more than one stdmsgs.h
   files.  One a legacy file, and one that is more consistent from
   message to message.. shooting for a gradual migration.

Let me know when you're back on planet earth ok?

Standardizing strings is an absolutely FRUITLESS exercise.

If you want events, standardize events and push them over
a queueing based communications channel to userspace, namely
using netlink sockets.
