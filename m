From: Gregory Carter <gcarter@aesgi.com>
Subject: Re: TESTING ROUTING CODE !!
Date: Thu, 16 Jul 2009 14:16:07 -0500
Message-ID: <4A5F7C77.3090806@aesgi.com>
References: <e49baca60907161039s7ceb493bje3b1a5c943ce5f33@mail.gmail.com>	 <A66C29B8-4F62-4180-8D93-DF3A46F77D5D@gmail.com>	 <e49baca60907161113s411e7d4ck472a9141881f56a1@mail.gmail.com> <f284c33d0907161134q20d01fc2wf63f484b63bb52d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Leena M." <kernmonk@gmail.com>, Kent Tu <kachin2@gmail.com>,
	"kernelnewbies@nl.linux.org" <kernelnewbies@nl.linux.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.aesgi.com ([207.234.130.182]:60509 "EHLO brahe.aesgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933223AbZGPUNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 16:13:25 -0400
In-Reply-To: <f284c33d0907161134q20d01fc2wf63f484b63bb52d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am currently using KVM.

Works very well for creating virtual networks, and testing iptable and 
marking of packets for different routing code tests.

I use KVM because it keeps all of the machines seperate, and of course, 
some of my machines are BSD.

So if you have different code bases you want to try your modifications 
with, KVM is a good choice IMHO.

-Gregory Carter
-Applied Engineering Software Group
-gcarter@aesgi.com

On 07/16/2009 01:34 PM, Mulyadi Santosa wrote:
> On Fri, Jul 17, 2009 at 1:13 AM, Leena M.<kernmonk@gmail.com>  wrote:
>> Any specific VM do you recommend , How about Xen ?
>>
>> Regards,
>> Leena
>
> Please don't top post...
>
> Since you talked about routing protocol, I think User Mode Linux would
> do just fine. It runs completely in user space and can be easily
> hooked with gdb.
>
>

