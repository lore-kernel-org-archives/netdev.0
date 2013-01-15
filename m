From: Stephen Hemminger <stephen@networkplumber.org>
Subject: iproute2 man7 patches
Date: Tue, 15 Jan 2013 09:39:57 -0800
Message-ID: <20130115093957.54f9f077@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:44667 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756990Ab3AOSbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 13:31:38 -0500
Received: by mail-pa0-f67.google.com with SMTP id fb11so275018pad.6
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 10:31:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did you look, the only reason man7 exists is that tc-hfsc is in the
wrong place. It should have been in section 8 all along, I will move it.
