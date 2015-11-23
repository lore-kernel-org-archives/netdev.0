From: Ldap Tester <ldap.tester@gmail.com>
Subject: Re: severe regression in alx ethernet driver
Date: Mon, 23 Nov 2015 11:00:08 -0300
Message-ID: <CAKM02HMMu_FVwSR7OpeyKQ=AUiCqwsjKgOCJJppJJG=tqz0Nog@mail.gmail.com>
References: <CAKM02HMP3WsRYTsm7UVR4tD1jMO5dHrDn6TXg9ARHo-Wqyq2oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33270 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbKWOAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 09:00:09 -0500
In-Reply-To: <CAKM02HMP3WsRYTsm7UVR4tD1jMO5dHrDn6TXg9ARHo-Wqyq2oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The severe regression in alx ethernet driver is still present in the
latest released kernel.  Patches have been posted in
https://bugzilla.kernel.org/show_bug.cgi?id=70761 There are reports
that these patches have resolved the problem.  Could you please review
these patches and see if they can be included upstream?  I have not
been able to update my kernel in almost six months.  Many other users
are suffering from this same problem.

On Mon, Sep 14, 2015 at 6:47 PM, Ldap Tester <ldap.tester@gmail.com> wrote:
> There is a serious regression in the alx ethernet driver.  The driver
> stopped working after upgrading the kernel from 4.0.x to 4.1.x.
> Please see https://bugzilla.redhat.com/show_bug.cgi?id=1251434 and
> https://bugzilla.kernel.org/show_bug.cgi?id=70761 This regression is
> urgent, as I cannot update my kernel to include the latest security
> fixes.
