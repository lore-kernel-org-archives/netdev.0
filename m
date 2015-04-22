From: s prasad <sprasad.kandregula@gmail.com>
Subject: Need help: Firmware(RT2870.bin) loading failed on "backports/stable/v3.14"
 - (Firmware copied at /lib/firmware)
Date: Wed, 22 Apr 2015 18:37:16 -0400
Message-ID: <CAJa-X95CsxD=xFK+OKBOPiaO6G_ZQcB2vGyzrF8wD0hzMYqmBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I am working on a project, in which need to enable wireless support.
My system have following configuration:
ARMv7 Processor(DLINK 868L router)
Linux-2.6

Have taken package from
"https://www.kernel.org/pub/linux/kernel/projects/backports/stable/v3.14/".
Am able to compile and load modules into system.

But when I am trying to enable interface by calling "ifconfig wlan0
up", am getting following error messages.

ieee80211 phy0: rt2x00lib_request_firmware: Info - Loading firmware
file 'rt2870.bin'
ieee80211 phy0: rt2x00lib_request_firmware: Error - Failed to request Firmware

Firmware (rt2870.bin) is there in the following location:
/lib/firmware.

Can somebody help me.

Thanks and Regards,
S Prasad Kandregula
