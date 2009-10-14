From: Brad Doctor <brad.doctor@gmail.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 11:02:01 -0600
Message-ID: <a07586b0910141002o31f1a480t306f36fe8da19427@mail.gmail.com>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
	 <4AD60053.1030804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Luca Deri <deri@ntop.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:32802 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760830AbZJNRCi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 13:02:38 -0400
Received: by pzk26 with SMTP id 26so10134250pzk.4
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 10:02:02 -0700 (PDT)
In-Reply-To: <4AD60053.1030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is for ntop, which uses PF_RING, but is a traffic analysis
application and is separate.

But you raise a good point and we will make the change for ntop.

thanks!
-brad

On Wed, Oct 14, 2009 at 10:46 AM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> Brad Doctor wrote, On 10/14/2009 04:33 PM:
>
>> into high-speed packet capture, and is homegrown. PF_RING uses the
>> stock GPL license.
>
>
> Are you sure you're using the stock GNU GPL?:
>
>> Download ntop
>>
>> ntop is distributed under the GNU GPL. In order to be entitled to do=
wnload ntop you must accept the GNU license.
>
> I can't find such a thing neither in GNU GPL v2:
>
> "5. =A0You are not required to accept this License, since you have no=
t signed it. However, nothing else grants you permission to modify or d=
istribute the Program or its derivative works. These actions are prohib=
ited by law if you do not accept this License. Therefore, by modifying =
or distributing the Program (or any work based on the Program), you ind=
icate your acceptance of this License to do so, and all its terms and c=
onditions for copying, distributing or modifying the Program or works b=
ased on it. "
>
> nor in GNU GPL v3:
>
> "9. Acceptance Not Required for Having Copies.
>
> You are not required to accept this License in order to receive or ru=
n a copy of the Program. Ancillary propagation of a covered work occurr=
ing solely as a consequence of using peer-to-peer transmission to recei=
ve a copy likewise does not require acceptance. However, nothing other =
than this License grants you permission to propagate or modify any cove=
red work. These actions infringe copyright if you do not accept this Li=
cense. Therefore, by modifying or propagating a covered work, you indic=
ate your acceptance of this License to do so."
>
> Thanks,
> Jarek P.
>
