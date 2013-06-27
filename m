From: Joe Perches <joe@perches.com>
Subject: Re: [RFC Patch net-next 1/5] net: introduce generic union inet_addr
Date: Thu, 27 Jun 2013 10:15:55 -0700
Message-ID: <1372353355.2060.22.camel@joe-AO722>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Landley <rob@landley.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Veaceslav Falico <vfalico@redhat.com>, Ding@jasper.es
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60925 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752030Ab3F0RP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 13:15:56 -0400
In-Reply-To: <1372315398-19683-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Hi Cong.

I think this is premature.

Please let the discussion and implementation
for %pI[gS]<foo> play out and be accepted
into next before using it in other subsystems.
