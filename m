From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] rocker: add change MTU support
Date: Thu, 9 Jul 2015 11:11:36 +0900
Message-ID: <20150709021134.GA26973@vergenet.net>
References: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34006 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbbGICLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 22:11:46 -0400
Received: by pdbep18 with SMTP id ep18so155570297pdb.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 19:11:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 04:06:47PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Implement ndo_change_mtu: on MTU change, reallocate Rx ring bufs and signal
> HW of new port MTU value.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Looks good :)

Reviewed-by: Simon Horman <simon.horman@netronome.com>
Tested-by: Simon Horman <simon.horman@netronome.com>
