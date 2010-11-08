From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.36 vlans & bridge crash - status?
Date: Mon, 8 Nov 2010 13:25:13 -0800
Message-ID: <AANLkTikjOEywPxLkTCPwAjmH78w0CYPm-fp2gDxzAfqN@mail.gmail.com>
References: <20101105103520.GA3577@pcnci.linuxbox.cz>
	<AANLkTin130xsLRQRMH2W6Yy=gJSD-qS29vR-E6Qvfgpg@mail.gmail.com>
	<20101106071115.GA3264@nik-comp.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev list <netdev@vger.kernel.org>, nikola.ciprich@linuxbox.cz
To: Nikola Ciprich <extmaillist@linuxbox.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59415 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab0KHVZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:25:16 -0500
Received: by eye27 with SMTP id 27so3139895eye.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 13:25:14 -0800 (PST)
In-Reply-To: <20101106071115.GA3264@nik-comp.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 6, 2010 at 12:11 AM, Nikola Ciprich <extmaillist@linuxbox.cz> wrote:
> Hello Jesse,
> It really fixes the problem, thanks!
> Was the patch submitted to Greg for 2.6.36.y ?

Thanks for testing.  I've submitted it to stable now.
