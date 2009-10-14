From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 18:46:11 +0200
Message-ID: <4AD60053.1030804@gmail.com>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Luca Deri <deri@ntop.org>
To: Brad Doctor <brad.doctor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:52164 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932265AbZJNQqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 12:46:54 -0400
Received: by fxm27 with SMTP id 27so11820207fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 09:46:18 -0700 (PDT)
In-Reply-To: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brad Doctor wrote, On 10/14/2009 04:33 PM:

> into high-speed packet capture, and is homegrown. PF_RING uses the
> stock GPL license.


Are you sure you're using the stock GNU GPL?:

> Download ntop
> 
> ntop is distributed under the GNU GPL. In order to be entitled to download ntop you must accept the GNU license. 

I can't find such a thing neither in GNU GPL v2:

"5.  You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to modify or distribute the Program or its derivative works. These actions are prohibited by law if you do not accept this License. Therefore, by modifying or distributing the Program (or any work based on the Program), you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or modifying the Program or works based on it. "

nor in GNU GPL v3:

"9. Acceptance Not Required for Having Copies.

You are not required to accept this License in order to receive or run a copy of the Program. Ancillary propagation of a covered work occurring solely as a consequence of using peer-to-peer transmission to receive a copy likewise does not require acceptance. However, nothing other than this License grants you permission to propagate or modify any covered work. These actions infringe copyright if you do not accept this License. Therefore, by modifying or propagating a covered work, you indicate your acceptance of this License to do so."

Thanks,
Jarek P.
