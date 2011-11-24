From: Jiri Pirko <jpirko@redhat.com>
Subject: libteam status
Date: Thu, 24 Nov 2011 10:42:08 +0100
Message-ID: <20111124094203.GA2393@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755128Ab1KXJmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 04:42:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys.

I just want you to be noted about current status of libteam.
Please pull the git (git@github.com:jpirko/libteam.git) if you are
interested to try.

The main news is that python binding ("team" module) is in nearly complete
phase. It's used by examples/python/team_daemon.py application which
implements very basic (ethtool link state monitoring) active backup
functionality.

I would be very pleased if you guys try and toy a little with it. I
would love to hear your feedback (on anything related).

The next station is c daemon with ability to interact with Network
Manager via dbus.

Thanks!

Jirka
