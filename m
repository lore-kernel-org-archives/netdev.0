From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: 3.8.4 kernel
Date: Tue, 7 May 2013 02:51:58 +0000
Message-ID: <157393863283F442885425D2C45428564F219B3B@nasanexd02f.na.qualcomm.com>
References: <5153620E.4010608@gmail.com>
 <CAErSpo6w+tTbwJ7Qinpd0Vx20q5cm2gMvqzE1Do+2=G3b8rcHA@mail.gmail.com>
 <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
 <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
	"Joseph A. Millikan" <josephamillikan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >
> > Did this ever get resolved?
> 
> I opened https://bugzilla.kernel.org/show_bug.cgi?id=57681 to keep track of
> this and attached the dmesg logs you collected.  If you have a chance, could you
> also collect and attach the output of "lspci -vv"
> (any kernel is fine for this).
> 
> I don't see anything obvious wrong, at least from the PCI side.  Maybe the atl1c
> guys will have some ideas.
> 

Hi Bjorn and All
     This issue should be same as bug https://bugzilla.kernel.org/show_bug.cgi?id=54021
     I didn't find any abnormal info from the log and the PHY link is stable as well :(
     Is it related to the network manager ?

BR.
Xiong
