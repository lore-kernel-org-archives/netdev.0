From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 06/21] switchdev: introduce switchdev add/del
 obj ops
Date: Wed, 6 May 2015 20:23:13 +0200
Message-ID: <20150506182313.GA2007@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37591 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFSXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:23:18 -0400
Received: by widdi4 with SMTP id di4so32562097wid.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:23:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:42PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Like switchdev attr get/set, add new switchdev obj add/del.  switchdev objs
>will be things like VLANs or FIB entries, so add/del fits better for
>objects than get/set used for attributes.
>
>Use same two-phase prepare-commit transaction model as in attr set.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
