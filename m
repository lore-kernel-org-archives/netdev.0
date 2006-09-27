From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac mtu
Date: Wed, 27 Sep 2006 15:55:16 +0200
Message-ID: <1159365316.2698.40.camel@ux156>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org>
	 <20060925200125.GF16949@tuxdriver.com>
	 <20060927143905.721ddf3e@griffin.suse.cz>
	 <1159365434.451a833ae7728@imp3-g19.free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:10401 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932180AbWI0Nyg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 09:54:36 -0400
To: castet.matthieu@free.fr
In-Reply-To: <1159365434.451a833ae7728@imp3-g19.free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 15:57 +0200, castet.matthieu@free.fr wrote:

> Also I wonder what should be the max mtu.

2304, I think, as that's
synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */

But maybe I'm interpreting the spec wrongly?

johannes
