From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4.21][FIX] use mod_timer
Date: Fri, 20 Jun 2003 10:03:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620.100329.74736219.davem@redhat.com>
References: <1056091000.1200.23.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo@hera.kernel.org, netdev@oss.sgi.com, jbarnes@sgi.com,
   alan@redhat.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vinay-rc@naturesoft.net
In-Reply-To: <1056091000.1200.23.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
   Date: 20 Jun 2003 12:06:40 +0530

   Hi,
   
   This patch makes use of mod_timer instead of {del,add}_timer.
   
I applied all of the networking ones already and sent it
off the Marcelo the other day, just waiting for him to
eat it.
