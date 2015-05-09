From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 13/23] switchdev: remove old
 switchdev_port_bridge_setlink
Date: Sat, 9 May 2015 20:49:56 +0200
Message-ID: <20150509184956.GE2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-14-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38706 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbbEISuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 14:50:01 -0400
Received: by wiun10 with SMTP id n10so58335234wiu.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 11:50:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-14-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:15PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>New attr-based bridge_setlink can recurse lower devs and recover on err, so
>remove old wrapper (including ndo_dflt_switchdev_port_bridge_setlink).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
