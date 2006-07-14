From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: I/O Acceleration Technology Nics
Date: Fri, 14 Jul 2006 10:38:14 -0700
Message-ID: <c0a09e5c0607141038r678f1c55w5bb48d4619f64e97@mail.gmail.com>
References: <d0383f90607140250u2e958470o4ba6b072dd57df3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.206]:17588 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1422676AbWGNRiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 13:38:16 -0400
Received: by wx-out-0102.google.com with SMTP id i28so289071wxd
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 10:38:16 -0700 (PDT)
To: "Ian Brown" <ianbrn@gmail.com>
In-Reply-To: <d0383f90607140250u2e958470o4ba6b072dd57df3d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/14/06, Ian Brown <ianbrn@gmail.com> wrote:
>   I came across the e1000 download for linux in intel site.
> I saw that in the readme they talk about Intel(R) I/O Acceleration Technology;
> According to this readme , there is support for "systems using the
> Intel(R) 5000 Series
> Chipsets Integrated Device - 1A38".
> see:
> http://downloadmirror.intel.com/df-support/9180/ENG/README.txt
>
> My question is : did anybody tried using chipsets with this I/O
> Acceleration Technology ?  Did he get a significant performance
> improvement over non
> I/O Accelerated nics ?

Perf results available here:
http://linux-net.osdl.org/index.php/I/OAT

Regards -- Andy
