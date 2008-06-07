From: Zsiros Attila <zsirmo@zsirmo.hu>
Subject: [Fwd: Re: bug report]
Date: Sat, 07 Jun 2008 09:45:32 +0200
Message-ID: <484A3C9C.2050302@zsirmo.hu>
Reply-To: zsirmo@zsirmo.hu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010005050103090902070407"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.zsirmo.hu ([84.21.11.243]:51177 "EHLO server.zsirmo.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520AbYFGH4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2008 03:56:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by server.zsirmo.hu (Postfix) with ESMTP id 1130318208CB
	for <netdev@vger.kernel.org>; Sat,  7 Jun 2008 09:45:23 +0200 (CEST)
Received: from server.zsirmo.hu ([127.0.0.1])
	by localhost (server.zsirmo.hu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LNIxkRd6uUHN for <netdev@vger.kernel.org>;
	Sat,  7 Jun 2008 09:45:22 +0200 (CEST)
Received: from [172.16.0.99] (catv-5985e327.catv.broadband.hu [89.133.227.39])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.zsirmo.hu (Postfix) with ESMTPSA id 1D9DE1827882
	for <netdev@vger.kernel.org>; Sat,  7 Jun 2008 09:45:22 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010005050103090902070407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------010005050103090902070407
Content-Type: message/rfc822;
 name="Re: bug report.eml"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Re: bug report.eml"

Delivered-To: zsirmo@gmail.com
Received: by 10.115.109.10 with SMTP id l10cs97400wam;
        Fri, 6 Jun 2008 18:44:37 -0700 (PDT)
Received: by 10.210.37.11 with SMTP id k11mr614653ebk.107.1212803076471;
        Fri, 06 Jun 2008 18:44:36 -0700 (PDT)
Return-Path: <oliver.pntr@gmail.com>
Received: from serv1.wnet.hu (serv1.wnet.hu [217.113.52.243])
        by mx.google.com with ESMTP id z34si4393998ikz.9.2008.06.06.18.44.34;
        Fri, 06 Jun 2008 18:44:36 -0700 (PDT)
Received-SPF: neutral (google.com: 217.113.52.243 is neither permitted nor denied by domain of oliver.pntr@gmail.com) client-ip=217.113.52.243;
Authentication-Results: mx.google.com; spf=neutral (google.com: 217.113.52.243 is neither permitted nor denied by domain of oliver.pntr@gmail.com) smtp.mail=oliver.pntr@gmail.com; dkim=pass (test mode) header.i=@gmail.com
Received: from localhost (localhost.wnet.hu [127.0.0.1])
	by serv1.wnet.hu (Postfix) with ESMTP id 8A15CAC985
	for <zsirmo@gmail.com>; Sat,  7 Jun 2008 03:44:32 +0200 (CEST)
X-Virus-Scanned: amavisd-new at wnet.hu
Received: from serv1.wnet.hu ([127.0.0.1])
	by localhost (serv1.wnet.hu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wm+ha9QXjnlA for <zsirmo@gmail.com>;
	Sat,  7 Jun 2008 03:44:31 +0200 (CEST)
Received: from fg-out-1718.google.com (fg-out-1718.google.com [72.14.220.154])
	by serv1.wnet.hu (Postfix) with ESMTP id 90C43AC97B
	for <zsirmo@zsirmo.hu>; Sat,  7 Jun 2008 03:44:31 +0200 (CEST)
Received: by fg-out-1718.google.com with SMTP id 16so889353fgg.44
        for <zsirmo@zsirmo.hu>; Fri, 06 Jun 2008 18:44:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from:to
         :subject:cc:in-reply-to:mime-version:content-type
         :content-transfer-encoding:content-disposition:references;
        bh=uhJjopsfiNIyxk3s3RiUcIdEfn12tiBIT6eir/RCaDA=;
        b=t47ZYbKXwvmMNVicE8Hgaw2hVsJrltrtZoRM9MoBVW5b2xcNb1QO9N308okr1xowib
         YSfOgDPVHkLJaEOcOjmVys5jTVHvZgDyVkTNUILoFoaCCAJDgSSCmA6xuqTLFugz5SKG
         q3aaqZkd1p8diyrKS0jSfgnwlNxj9BJkr0AGo=
DomainKey-Signature: a=rsa-sha1; c=nofws;
        d=gmail.com; s=gamma;
        h=message-id:date:from:to:subject:cc:in-reply-to:mime-version
         :content-type:content-transfer-encoding:content-disposition
         :references;
        b=ZSmHIieOHfnnebXDxiU+ljAuEjfkLrw1uCI8dPjEv5yAtsseibxGZCzdWnngiacd5+
         gLd3NYSP1pLjp4wwhGZeInvNDu1SJnkvhDysdaDBSdDfgKqmcP2fdiiRbC0uEHcrrelC
         5M7RrAS5SW3ENRVES+/fKkAS/idwxbwU+ksAo=
Received: by 10.86.80.17 with SMTP id d17mr1230483fgb.47.1212803072552;
        Fri, 06 Jun 2008 18:44:32 -0700 (PDT)
Received: by 10.86.31.3 with HTTP; Fri, 6 Jun 2008 18:44:32 -0700 (PDT)
Message-ID: <6101e8c40806061844g5b7676d4xb48c5c69ad48391f@mail.gmail.com>
Date: Sat, 7 Jun 2008 03:44:32 +0200
From: "Oliver Pinter" <oliver.pntr@gmail.com>
To: zsirmo@zsirmo.hu
Subject: Re: bug report
Cc: linux-kernel@vger.kernel.org, "Ingo Molnar" <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <48499731.1080807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48499731.1080807@gmail.com>

Add Ingon and netdev to CC


On 6/6/08, Zsiros Attila <zsirmo@gmail.com> wrote:
> Hy!
>
> I have a problem.
>
> http://www.cyberszeg.hu/log/kern.log
> http://www.cyberszeg.hu/log/config-2.6.25.4
> http://www.cyberszeg.hu/log/lspci.txt
> http://www.cyberszeg.hu/log/ifconfig.txt
>
> Best regards Zsirmo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


-- 
Thanks,
Oliver

--------------010005050103090902070407--
