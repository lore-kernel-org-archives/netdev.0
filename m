From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch for NETLINK_TCPDIAG
Date: Tue, 20 May 2003 19:33:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.193312.10304523.davem@redhat.com>
References: <OF172D8043.CEAC83BF-ON88256D2C.0066D5DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com
In-Reply-To: <OF172D8043.CEAC83BF-ON88256D2C.0066D5DE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <kumarkr@us.ibm.com>
   Date: Tue, 20 May 2003 11:49:43 -0700
   
   I am not sure if there is a reason why ACK cannot be set for
   NETLINK_TCPDIAG.
   If it is settable, please apply following patch.

Your patch does not apply, Lotus NOTES changes tabs into
spaces making the patch unusable.

I've added the fix by hand... but please be mindful of this
in the future.
