From: "David S. Miller" <davem@redhat.com>
Subject: Re: [rfc] sk_write_space() for atm
Date: Tue, 24 Jun 2003 17:40:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.174042.27809957.davem@redhat.com>
References: <20030624.163517.15237390.davem@redhat.com>
	<200306250032.h5P0WJsG010081@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
In-Reply-To: <200306250032.h5P0WJsG010081@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 24 Jun 2003 20:30:12 -0400

   comments?

This looks ok to me, but I am not well versed in this
area.  For example, if you give a spurious wakeup via
poll() what can happen?
