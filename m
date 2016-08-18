From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 18 Aug 2016 12:56:20 -0500
Message-ID: <57B5F6C4.2010603@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
 <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
 <57B4C6EE.3080903@codeaurora.org> <57B4E5F7.9040500@codeaurora.org>
 <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com>
 <57B52B17.1080809@codeaurora.org>
 <5CCEFB33-8F93-40D7-BD32-ACDE1CBA586D@gmail.com>
 <57B5374B.6010805@codeaurora.org>
 <3D5C1ACB-4338-4A9F-9BCC-0424A1793664@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        linux-arm-msm <linux-arm-msm@vger.kernel.org>,
        Sagar Dharia <sdharia@codeaurora.org>,
        Shanker Donthineni <shankerd@codeaurora.org>,
        Vikram Sethi <vikrams@codeaurora.org>,
        Christopher Covington <cov@codeaurora.org>,
        Gilad Avidov <gavidov@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Mark Langsdorf <mlangsdo@redhat.com>,
        "jcm@redhat.com" <jcm@redhat.com>,
        Andy Gross <agross@codeaurora.org>,
        David Miller <davem@davemloft.net>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        "Abdulhamid, Harb" <harba@codeaurora.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Al Stone <al.stone@linaro.org>, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <3D5C1ACB-4338-4A9F-9BCC-0424A1793664@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> There is a helper function to obtain the platform device associated with a device_node: of_find_device_by_node.

Thank you, this is exactly what I needed.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
