From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH] be2net: Delete an unnecessary check in two functions
Date: Wed, 6 Jan 2016 11:55:11 +0530
Message-ID: <CAKvpyk1WPROG=FH0Wcvfdum3YTFprELNftzX0pT9-PU7TDz8jQ@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<5685B8AD.7010900@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5685B8AD.7010900@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 1, 2016 at 4:52 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 00:11:57 +0100
>
> Remove two checks for null pointers which would be handled by usual
> error detection before.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Sathya Perla <sathya.perla@avagotech.com>

This patch is suitable for the net-next tree. Thanks!
