From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 07/21] switchdev: add port vlan obj
Date: Wed, 6 May 2015 20:23:35 +0200
Message-ID: <20150506182335.GB2007@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-8-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33968 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFSXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:23:39 -0400
Received: by wgso17 with SMTP id o17so20768876wgs.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:23:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-8-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:43PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
>The switchdev driver can optimize programing the device using the ranges.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
