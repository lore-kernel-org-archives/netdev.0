From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Thu, 09 Jul 2015 10:48:22 +0200
Message-ID: <559E3556.3050803@hartkopp.net>
References: <559D628C.5020100@hartkopp.net> <CAOpc7mEEOHr=QWazthRuWuoOvr_C_4O1hO8bP-N36tLT+RBifw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	therbert.google.com@vger.kernel.org,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	sunil.kovvuri@gmail.com, jonathon.reinhart@gmail.com
To: Holger Schurig <holgerschurig@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAOpc7mEEOHr=QWazthRuWuoOvr_C_4O1hO8bP-N36tLT+RBifw@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.07.2015 08:34, Holger Schurig wrote:
>> and has to be done by hand depending on where the CAN interfaces
>> are attached to the system.
>
> No ...  udev rules rock!   :-)
>

Yeah. But it can not be the approach to fix a known problem in the kernel by 
urging people to make workarounds in userspace. For my testing I did it by 
hand. But in real life the kernel has to do 'the right thing' by having wise 
defaults without interaction.

Regards,
Oliver
