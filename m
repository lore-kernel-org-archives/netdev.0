From: Arthur Rinkel <arthur@unimatrix001.student.utwente.nl>
Subject: i82596 ethernet controller
Date: Sat, 2 Oct 2004 23:50:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002235011.A24086@unimatrix001.student.utwente.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Recently I've purchased an Intel EtherExpress Pro/10 PCI which is based on
an i82596 ethernet controller. Although a driver exists for the controller,
no driver exists for the PCI-card; existing drivers only support ISA-based
cards for example.
I'd like to adapt the existing driver so it'll support the PCI-based card.
However, I don't know how this card is mapped into memory, so I can't
communicate with it.
There is some information available about the i82596, but this concerns the
chip only, not the card. Furthermore, Intel offers no longer support for
the card.
Any help appreciated.

Grtz, Arthur
