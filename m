From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 10/13] vxlan: do not shadow flags variable
Date: Wed, 19 Aug 2015 19:52:11 +0200
Message-ID: <20150819175211.GA5564@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <90a1de02af35b7162dafc47049c8da11f921ce3c.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38065 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbbHSUpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:45:55 -0400
Received: by wicja10 with SMTP id ja10so18820492wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:45:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <90a1de02af35b7162dafc47049c8da11f921ce3c.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:10pm, Jiri Benc wrote:
> The 'flags' variable is already defined in the outer scope.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
