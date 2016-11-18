From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 15:33:43 +0530
Message-ID: <CAFcVECK7ocXdmcnWmKBjZ8b2NEs0uwegD3+NtHzBUqfWw_1Ypg@mail.gmail.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com> <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com>
 <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <a315b554-8b44-ac82-a104-e382940750bb@atmel.com> <BN3PR07MB251655CAFDB38CCF0F240BB5C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJT=b2jmQAtsTeXEwWad8L2VEVW1GOyTY9XYR5qUq=4Mw@mail.gmail.com> <BN3PR07MB25162D82CEF09B8C7586B799C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR07MB25162D82CEF09B8C7586B799C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafal,


> I can=E2=80=99t see a place where you enable extended descriptor for PTP.=
 Did you add support for extended PTP descriptor?
Sorry, that was separate patch in the series:
http://lkml.iu.edu/hypermail/linux/kernel/1509.1/02239.html

> "DMA Configuration Register" 0x010:
> 29      tx_bd_extended_mode_en  "Enable TX extended BD mode. See TX BD co=
ntrol register definition for description of feature."
> 28      rx_bd_extended_mode_en  "Enable RX extended BD mode. See RX BD co=
ntrol register definition for description of feature."
>
> Can I send you our patch for comparison ?
Sure, please mail. Also, please mention the Cadence IP version number you u=
se.

Regards,
Harini
