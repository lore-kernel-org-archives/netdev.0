From: Robin Humble <rjh@cita.utoronto.ca>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 09:56:33 -0400
Message-ID: <20070915135633.GA19482@lemming.cita.utoronto.ca>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46EADC02.9070409@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik wrote:
>It is my hope that you will put your skills towards a distributed 
>filesystem :)  Of the current solutions, GFS (currently in kernel) 
>scales poorly, and NFS v4.1 is amazingly bloated and overly complex.
>
>I've been waiting for years for a smart person to come along and write a 
>POSIX-only distributed filesystem.

it's called Lustre.
works well, scales well, is widely used, is GPL.
sadly it's not in mainline.

cheers,
robin
