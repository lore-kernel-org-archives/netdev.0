From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] sysfs cleanup and bugfix
Date: Thu, 29 May 2003 20:05:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.200514.55840993.davem@redhat.com>
References: <20030529103011.3f038db7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030529103011.3f038db7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 29 May 2003 10:30:11 -0700

   A couple of bugs in netdev_unregister_sysfs; still working on the harder
   refcount issues.

Applied.  Stephen, I'll hack on the unregister issues with Al Viro.  I
think his scheme is the way to go.
