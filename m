From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Wed, 25 Apr 2007 11:54:50 -0400
Message-ID: <1177516490.9923.7.camel@localhost>
References: <1177515761.9923.3.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:60316 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031151AbXDYPyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 11:54:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so279745wxd
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 08:54:53 -0700 (PDT)
In-Reply-To: <1177515761.9923.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


That patch has xfrm_state_num being mucked with; just ignore that bit.
I need to send a patch against net-2.6.22 and i will clean that up -
just need some feedback.

Would it make sense to have those vars as u32 instead of unsigned int?

cheers,
jamal

