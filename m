From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH 0/7][RFC] FUJITSU Extended Socket network device driver
Date: Thu, 21 May 2015 03:16:41 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422DCC0@G01JPEXMBYT01>
References: <E86EADE93E2D054CBCD4E708C38D364A5422D803@G01JPEXMBYT01>
 <20150520144711.GE22037@vmdeb7>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: Darren Hart <dvhart@infradead.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20150520144711.GE22037@vmdeb7>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Darren, Alex,

  Thanks for your comments. I'll appreciate your help.  
  I'll resend new patchset to be updated according to your comments.

  Sincerely,
  Taku Izumi


> -----Original Message-----
> From: Darren Hart [mailto:dvhart@infradead.org]
> Sent: Wednesday, May 20, 2015 11:47 PM
> To: Izumi, Taku/泉 拓
> Cc: platform-driver-x86@vger.kernel.org; Hart, Darren; rkhan@redhat.com; alexander.h.duyck@redhat.com;
> netdev@vger.kernel.org; linux-acpi@vger.kernel.org
> Subject: Re: [PATCH 0/7][RFC] FUJITSU Extended Socket network device driver
> 
> On Wed, May 20, 2015 at 08:04:07AM +0000, Izumi, Taku wrote:
> > Hi All,
> >
> > This patchsets add support for FUJITSU Extended Socket network
> > device. Extended Socket network device is a shared memory
> > based high-speed network interface between Extended Partitions of
> > PRIMEQUEST 2000 E2 series.
> 
> Hi Taku,
> 
> A few things to keep in mind.
> 
> 1) Always Cc the maintainer using the email address in the MAINTAINERS file,
>    in this case, dvhart at infradead.org.
> 
> 2) See Documentation/email-clients.txt regarding charset (you sent ISO-2022,JP):
> 
>    Email clients should not modify the character set encoding of the text.
>    Emailed patches should be in ASCII or UTF-8 encoding only.
>    If you configure your email client to send emails with UTF-8 encoding,
>    you avoid some possible charset problems.
> 
> 3) A new driver should be functional at each patch point, so committing a
>    skeleton that does nothing is not what we're looking for by "small functional
>    changes".
> 
> Thanks,
> 
> --
> Darren Hart
> Intel Open Source Technology Center
