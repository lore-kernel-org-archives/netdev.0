From: Jeff Dike <jdike@addtoit.com>
Subject: Re: locking issue in vhost_net_set_backend
Date: Tue, 16 Mar 2010 12:11:33 -0400
Message-ID: <20100316161133.GA1465@localhost.localdomain>
References: <4B9F8E7F.7070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B9F8E7F.7070709@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2010 at 02:58:23PM +0100, Jiri Slaby wrote:
> I don't see how the lock is unlocked on the error paths and as it is not  
> on none of the them maybe I'm missing something?

I sent Michael a patch for this a couple of weeks ago.

				Jeff

-- 
Work email - jdike at linux dot intel dot com
