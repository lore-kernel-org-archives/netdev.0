From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Fri, 25 Nov 2016 09:55:39 +0100
Message-ID: <5d59aac4-1616-5316-a624-192b390d1569@st.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
 <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
 <BFA799B0-BB22-4515-AC14-3544A3167B0A@axis.com>
 <ffd3b27c-0bc9-b53b-cc65-c7808595a553@st.com>
 <b126021d-e902-7a53-4d7a-e73ea89a66cf@synopsys.com>
 <A001080B-2DC8-48D9-BD82-8276A9B3BE3D@axis.com>
 <7c7798b5-8cd4-ba99-f526-22d3e06e05db@synopsys.com>
 <2eefdb8f-7e87-6009-6e50-c536d4b95dd6@synopsys.com>
 <c37c47e1-8e21-1b11-ed15-6b899ed1dd03@st.com>
 <7c259adb-5c73-f997-6b96-5be427157b08@synopsys.com>
 <899DC02E-84BB-489E-A1FE-5D8F3BB795B6@axis.com>
 <f4dd5d22-4467-d046-6b65-2a28f3fc5a7c@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "idosch@mellanox.com" <idosch@mellanox.com>,
 "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
 "saeedm@mellanox.com" <saeedm@mellanox.com>, netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "CARLOS.PALMINHA@synopsys.com" <CARLOS.PALMINHA@synopsys.com>,
 Rabin Vincent <rabin@rab.in>, mued dib <kreptor@gmail.com>,
 "jiri@mellanox.com" <jiri@mellanox.com>,
 Rayagond Kokatanur <rayagond@vayavyalabs.com>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 =?UTF-8?Q?Andreas_Irest=c3=a5l?= <andire@axis.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, Lars Persson <lars.persson@axis.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <f4dd5d22-4467-d046-6b65-2a28f3fc5a7c@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 11/23/2016 12:43 PM, Joao Pinto wrote:
>> > Rabin Vincent can review and test that the port works properly on our Artpec-chips that use dwc_eth_qos.c today.
>> >
>> > The main porting step is to implement the device tree binding in bindings/net/snps,dwc-qos-ethernet.txt. Also our chip has a strict requirement that the phy is enabled when the SWR reset bit is set (it needs a tx clock to complete the reset).
>> >
>> > - Lars
> Ok, I will do the task.
>
> @Peppe: Agree with the plan?

Agree

peppe
