From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next v5 06/21] switchdev: introduce switchdev add/del
 obj ops
Date: Tue, 05 May 2015 23:37:38 -0700
Message-ID: <5549B6B2.3040702@intel.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com> <1430847297-15728-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40051 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbbEFGhj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 02:37:39 -0400
In-Reply-To: <1430847297-15728-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/2015 10:34 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Like switchdev attr get/set, add new switchdev obj add/del.  switchdev objs
> will be things like VLANs or FIB entries, so add/del fits better for
> objects than get/set used for attributes.
>
> Use same two-phase prepare-commit transaction model as in attr set.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

Will submit a patch tomorrow to add support for fdb objects.

Thanks
Sridhar
