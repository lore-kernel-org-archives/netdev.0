From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 15:28:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251928.h8PJSZkT011995@ginger.cmf.nrl.navy.mil>
References: <levon@movementarian.org>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Levon <levon@movementarian.org>
In-Reply-To: Message from John Levon <levon@movementarian.org>
   of "Thu, 25 Sep 2003 18:03:42 BST." <20030925170342.GA74937@compsoc.man.ac.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030925170342.GA74937@compsoc.man.ac.uk>,John Levon writes:
>atm-ioctl6.diff isn't applying properly now for some reason though.

it applies to a bk pull from this morning w/o any trouble afaict.

>I guess it's fine to apply the old patchset anyway, it should be pretty
>easy for Mitchell to add a diff before his stuff that represents the
>changes between my two sets of patches.

i redid your patch set a bit to just get from point a to b w/o
the phantom ioctl.h and with the ATM_VF_IS_CLIP change discussed earlier.
