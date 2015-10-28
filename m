From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: bridge: use vzalloc() instead of vmalloc()
 as counterstmp is not cleared before it is used in get_counters().
 counterstmp might be leaked partially when it is sent to userland later on.
Date: Wed, 28 Oct 2015 21:10:20 +0300
Message-ID: <56310F8C.2080201@cogentembedded.com>
References: <20151028155654.GA2775@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Loganaden Velvindron <logan@elandsys.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33017 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbbJ1SKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 14:10:25 -0400
Received: by lbbec13 with SMTP id ec13so12066827lbb.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 11:10:23 -0700 (PDT)
In-Reply-To: <20151028155654.GA2775@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    Your subject is too long, it should have been placed in the changelog 
partially. You you didn't sign off on the patch, so it can't applied.

MBR, Sergei
