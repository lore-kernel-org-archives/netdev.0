From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 01:55:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.015533.77059614.davem@redhat.com>
References: <20030625.205941.41631020.davem@redhat.com>
	<20030626085307.096652C0B4@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030626085307.096652C0B4@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Thu, 26 Jun 2003 18:17:45 +1000
   
   If the first one isn't happening, this patch is doubly useless 8)

It does happen, but so does reordering on ethernet itself.
