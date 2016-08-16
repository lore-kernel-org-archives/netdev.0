From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v5 3/3] net: phy: Add gmiitorgmii converter support
Date: Tue, 16 Aug 2016 18:09:59 +0200
Message-ID: <20160816160959.GO14446@lunn.ch>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-4-git-send-email-appanad@xilinx.com>
 <20160815213059.GK24664@lunn.ch>
 <C246CAC1457055469EF09E3A7AC4E11A4A5E2756@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "robh+dt@kernel.org" <robh+dt@kernel.org>, Michal Simek <michals@xilinx.com>,
 Soren Brinkmann <sorenb@xilinx.com>,
 Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <C246CAC1457055469EF09E3A7AC4E11A4A5E2756@XAP-PVEXMBX01.xlnx.xilinx.com>
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

> > https://github.com/lunn/linux/commit/03d375489ceb56e171056f44d0fe9c34ca
> > 5a098e
> > 
> > Notice the
> > 
> > Not-Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > 
> > and the Copyright i added?
> > 
> > In various emails i gave you the basic idea how this should be done, a framework
> > of code, and then took your code which did not even compile and made the core
> > of it work. This is as much my code as your code, so i expect my Copyright to be
> > kept on this code. And since this is my code, i need to give a Signed-off-by,
> > which i was not yet ready to give since the code was not complete or working.
> > 
> > Please put both my Copyright back and Not-Signed-Off-by back and post the
> > next version as RFC. Once i'm happy this code is O.K, i will give you a Signed-off-
> > by.
> 
> Sorry I should have been included your copyright.
> 
> I missed it...
> I didn't included your SOF because.
> AFAIK without explicit permission of the other person we shouldn't include SOF.
> That's why I didn't included your SOF and thanked for your efforts after SOF.
> Sorry if my understanding is wrong.

Without a SOB you cannot submit the patch for inclusion at all. You
should however reproduce tags which have been given, i.e. you should
of kept my Not-Signed-Off-by: making it clear i have not yet given
permission for this code to go into mainline.

	   Andrew
